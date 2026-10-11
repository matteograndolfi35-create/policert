#!/usr/bin/env bash
# Uso: ./setup.sh <nome-repo> [username-github-del-compagno]
# Richiede: git, GitHub CLI (gh) già autenticata con `gh auth login`.
set -euo pipefail

REPO="${1:-policert}"
MATE="${2:-}"

git init -b main
git add .
git commit -m "chore: struttura iniziale del repository"

gh repo create "$REPO" --private --source=. --remote=origin --push
OWNER="$(gh api user --jq .login)"

git checkout -b develop
git push -u origin develop

# Etichette
for l in "feature:0e8a16" "bug:d73a4a" "docs:0075ca" "test:fbca04" \
         "priorita-alta:b60205" "priorita-media:ff9f1c" "priorita-bassa:c2e0c6" \
         "area-contracts:5319e7" "area-backend:1d76db" "area-frontend:bfdadc"; do
  gh label create "${l%%:*}" --color "${l##*:}" --force || true
done

# Milestone
for m in "M1 - Relazione parziale (novembre)" "M2 - MVP funzionante" "M3 - Consegna finale (dicembre)"; do
  gh api -X POST "repos/$OWNER/$REPO/milestones" -f title="$m" >/dev/null || true
done

# Invito del compagno
if [ -n "$MATE" ]; then
  gh api -X PUT "repos/$OWNER/$REPO/collaborators/$MATE" -f permission=push >/dev/null
  echo "Invito inviato a $MATE"
fi

# Protezione dei branch (1 approvazione + CI verde)
protect() {
  gh api -X PUT "repos/$OWNER/$REPO/branches/$1/protection" --input - >/dev/null <<JSON
{
  "required_status_checks": { "strict": true, "contexts": ["build-and-test"] },
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 1 },
  "restrictions": null
}
JSON
}

for b in main develop; do
  protect "$b" || echo "ATTENZIONE: protezione di '$b' non applicata (repo privato senza piano a pagamento? vedi README del setup)."
done

echo "Fatto: https://github.com/$OWNER/$REPO"
