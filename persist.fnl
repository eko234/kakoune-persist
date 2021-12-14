(lambda [db_path]
  (let 
    [db ((require :flat) db_path)]
    {:save 
     (lambda [category key value]
       (tset db category key {: value :hot (os.time)})
       (db:save))

     :load 
     (lambda [category key]
       (let
         [value (. db category key :value)]
         (tset db category key :hot (os.time))
         (db:save)
         value))
     
     :list
     (lambda [category]
       (let
         [category_map (. db category)
          sorting_done (table.sort category_map (fn [a b] (> a.hot b.hot)))]
         (table.concat (icollect [i e (ipairs category_map)] (string.format "%s:%s" i e.value)) "\n")))}))
