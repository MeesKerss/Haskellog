Each subfolder is one test:

  program.pl   — clauses (rule bodies: comma between goals, as in Prolog)
  query.txt    — one line, a Prolog query (optional trailing dot)
  expected.txt — one output line per answer, sorted alphabetically.
                 Use a single line "true." for a ground query that succeeds,
                 "false." for no solutions or ground failure.

Variable order in answers is alphabetical (X before Y).
