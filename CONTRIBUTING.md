# Regole di lavoro

## Branch
- `main`: stabile, solo release taggate. Protetto.
- `develop`: integrazione. Protetto.
- `feature/<nome>`, `fix/<nome>`, `docs/<nome>`: rami di breve durata creati da `develop`.
- `hotfix/<nome>`: correzioni urgenti create da `main` (uso raro).

## Pull request
1. Ogni modifica a `develop` e `main` passa da una pull request.
2. Approvazione dell'altro membro del gruppo.
3. CI verde prima del merge.
4. Collega la issue (`Closes #n`).
5. Squash merge su `develop`; merge commit da `develop` a `main`, con tag.

## Commit (Conventional Commits)
`tipo(ambito): descrizione`, con tipi `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`.

Esempio: `feat(contracts): aggiunge revoca certificato`

## Sicurezza
Mai committare chiavi private, mnemonic o file `.env`. Usa `.env.example`.
