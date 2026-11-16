# COMMITMENTS: the owner's ordered list (copy to .team/COMMITMENTS.md)

Read by `scripts/commitments` and `enforcement/new-session`. Its presence turns the management
checks on (see `templates/method.md`).

- Row ORDER is the priority. The owner orders it, once a week. The top open row is the only open
  row a producer session may start.
- `id` matches the task id on the board (`.team/TASKS.md`) so done-check can resolve it.
- `status`: `open` | `active` | `blocked: <reason>` | `done`. Use the script to change it
  (`dispatch`, `block`, `done`). `finished` and `stamp` are written only by `commitments done`,
  after done-check exits 0. A `done` row with no stamp is reported as NOT DONE.
- No pipes and no line breaks inside a cell.

| id | commitment | status | finished | stamp |
|---|---|---|---|---|
| T1-example | the outcome the owner asked for, in the owner's words | open | | |
