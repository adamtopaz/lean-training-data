#!/usr/bin/env bash

# Run either as `scripts/tactic_benchmark.sh --aesop` to run aesop on all of Mathlib,
# or `scripts/tactic_benchmark.sh --simp_all Mathlib.Logic.Hydra` to run on just one file.
# Results will go in `out/tactic_benchmark/simp_all/Mathlib.Logic.Hydra.bench`.


if [ "$#" -eq 1 ]; then
  lake build tactic_benchmark
  parallel -j32 ./scripts/tactic_benchmark.sh $1 -- ::: `cat .lake/packages/mathlib/Mathlib.lean | sed -e 's/import //'`
else
  DIR=out/tactic_benchmark/${1#--}
  mkdir -p $DIR
  mod=$2
  if [ ! -f $DIR/$mod.bench ]; then
    echo $mod
    if [ ! -f .lake/build/bin/tactic_benchmark ]; then
      lake build tactic_benchmark
    fi
    timeout 5m .lake/build/bin/tactic_benchmark $1 $mod > $DIR/$mod._bench && mv $DIR/$mod._bench $DIR/$mod.bench
  fi
fi
