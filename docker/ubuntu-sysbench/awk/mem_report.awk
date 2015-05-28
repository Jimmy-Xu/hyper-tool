#!/usr/bin/awk

BEGIN{
}
/Memory Test -/{
  target=$8" | mem | "$5"-"$6
}
/^test_case: /{
  test_case=$2
  key=target" | "test_case
}
/Number of threads/{
  f_threads[key]=$4
}
/ transferred /{
  f_totol_size[key]=$1
  sub(/[(]/,"",$4)
  f_speed[key]=$4
}
/    total time:/{
  sub("s","",$3)
  f_time[key]=$3
}
/min:/{
  sub("ms","",$2)
  f_min[key]=$2
}
/avg:/{
  sub("ms","",$2)
  f_avg[key]=$2
}
/max:/{
  sub("ms","",$2)
  f_max[key]=$2
}
END{
  print "| target | item | test-mode | test-case | threads | total-size | speed(MB/sec) | time(sec) | min(ms) | avg(ms) | max(ms) |"
  print "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"
  for ( i in f_time ){
    printf "| %-6s | %s | %s | %s | %s | %s | %s | %s |\n", i, f_threads[i], f_totol_size[i], f_speed[i], f_time[i], f_min[i], f_avg[i], f_max[i]
  }
}