#region subexpressions

#single subexpression

'202-555-0148' -match '(202)-555-0148'

#double subexpression

'202-555-0148' -match '(\d+)-(\d+-\d+)'

#non-capturing subexpression

'202-555-0148' -replace '(?:\d{3}-)+(\d{4})','$1'

#repeating subexpressions

'202-555-0148' | Select-String -Pattern '(\d+)+' -All | % matches

#endregion