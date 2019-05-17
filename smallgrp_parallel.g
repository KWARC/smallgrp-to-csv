write_smallgrp_csv := function(fname, order_range, nr_threads)
  local out, funcs, nrgroups, groups_started, start_time, func, children, 
        range_index, size, nrgroupssize, id, time_so_far, time_per_gp, 
        time_left, child, G, string, subfname, i, line;
  out := OutputTextFile(fname, false);
  
  # Properties stored in smallgrp
  funcs := [IsAbelian,
            IsNilpotentGroup,
            IsSupersolvableGroup,
            IsSolvableGroup,
            #RankPGroup,
            #PClassPGroup,
            LGLength,
            FrattinifactorSize,
            G -> FrattinifactorId(G)[2],
            StructureDescription];  # this is the long one
  
  nrgroups := Sum(order_range, NrSmallGroups);
  groups_started := 0;
  start_time := IO_gettimeofday().tv_sec;
  
  AppendTo(out, "order,id");
  for func in funcs do
    AppendTo(out, ",", NameFunction(func));
  od;
  AppendTo(out, "\n");
  
  children := [];
  range_index := 1;
  size := order_range[range_index];
  nrgroupssize := NrSmallGroups(size);
  id := 1;
  
  while groups_started < nrgroups or Length(children) > 0 do
    
    # Create new threads
    while Length(children) < nr_threads and groups_started < nrgroups do
      groups_started := groups_started + 1;
      time_so_far := IO_gettimeofday().tv_sec - start_time;
      time_per_gp := time_so_far / Maximum(1, groups_started - nr_threads);
      time_left := time_per_gp * (nrgroups - groups_started + nr_threads/2);
      time_left := Float(time_left);
      Print("Starting group ", groups_started, " of ", nrgroups,
            " (", Int(Float(groups_started / nrgroups * 100)), "%): [", 
            size, ", ", id, "], ", 
            Int(Round(time_left)), " seconds or ",
            Int(Round(time_left/60)), " minutes or ",
            Int(Round(time_left/3600)), " hours left.   \r");
      child := IO_fork();
      if child = fail then
        Error("cannot create children!");
      elif child <> 0 then
        # Parent
        Add(children, child);
        if id < nrgroupssize then
          id := id + 1;
        else
          range_index := range_index + 1;
          if range_index > Length(order_range) then
            break;  # no more groups!
          fi;
          size := order_range[range_index];
          nrgroupssize := NrSmallGroups(size);
          id := 1;
        fi;
      else
        # Child
        G := SmallGroup(size, id);
        string := Concatenation(String(size), ",", String(id));
        for func in funcs do
          Append(string, ",");
          Append(string, String(func(G)));
        od;
        Append(string, "\n");
        subfname := Concatenation("output-", String(IO_getpid()), ".g");
        FileString(subfname, string);
        QUIT_GAP(0);
      fi;
    od;
  
    # Wait for threads to finish
    for i in [1 .. Length(children)] do
      if IO_WaitPid(children[i], false) <> false then
        # Finished!
        child := Remove(children, i);
        subfname := Concatenation("output-", String(child), ".g");
        #Print("Got ", subfname, "\n");
        line := StringFile(subfname);
        RemoveFile(subfname);
        AppendTo(out, line);
        break;
      fi;
    od;

  od;

  CloseStream(out); 
  time_so_far := IO_gettimeofday().tv_sec - start_time;
  return time_so_far;
end;
