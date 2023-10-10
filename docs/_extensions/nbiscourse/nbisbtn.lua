function Div(div)
  -- process exercise
  if div.classes:includes("nbisbtn") then
    if div.c[1].t == "Para" then
      local newcontent = div.c[1].c
      div.content = newcontent
    end
  end
  return div
end
