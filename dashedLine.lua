function dashedLine(x1, y1, x2, y2, dash, gap)
   local dy, dx = y2 - y1, x2 - x1
   local an, st = math.atan2(dy, dx), dash + gap
   local len = math.sqrt(dx*dx + dy*dy)
   local nm = (len - dash) / st
   love.graphics.push()
      love.graphics.translate(x1, y1)
      love.graphics.rotate(an)
      for i = 0, nm do
         love.graphics.line(i * st, 0, i * st + dash, 0)
      end
      love.graphics.line(nm * st, 0, nm * st + dash,0)
   love.graphics.pop()
end
