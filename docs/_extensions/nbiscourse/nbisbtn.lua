function Div(div)
  -- process exercise
  if div.classes:includes("nbisbtn") then
    div.content = pandoc.utils.stringify(div.content)
  end
  return pandoc.Div(div)
end
