#!/usr/bin/awk

BEGIN{
}
/CPU Performance Test/{
  key=$6
}
/Number of threads/{
  f_threads[key]=$4
}
/Primer numbers limit/{
  f_primer[key]=$4
}
/    total time:/{
  sub("s","",$3)
  f_time[key]=$3
}
END{
  print "| - | num-threads | cpu-max-prime | total time(sec) |"
  print "| --- | --- | --- | --- |"
  for ( item in f_time ){
    printf "| %-6s | %s | %s | %s |\n", item, f_threads[item], f_primer[item], f_time[item]
  }
}