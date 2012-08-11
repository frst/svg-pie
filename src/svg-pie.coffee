class Color
        rgb_to_hsv: (r, g, b)->
                maxc= Math.max(r, g, b)
                minc= Math.min(r, g, b)
                v= maxc
                if minc == maxc then return [0, 0, v]
                diff= maxc - minc
                s= diff / maxc
                rc= (maxc - r) / diff
                gc= (maxc - g) / diff
                bc= (maxc - b) / diff
                if r == maxc
                        h= bc - gc
                else if g == maxc
                        h= 2.0 + rc - bc
                else
                        h = 4.0 + gc - rc
                h = (h / 6.0) % 1.0 # this calculates only the fractional part of h/6
                return [h, s, v]

        hsv_to_rgb: (h, s, v)->
                if s == 0.0 then return [v, v, v]
                i= parseInt(Math.floor(h*6.0), 10) # floor() should drop the fractional part
                f= (h*6.0) - i
                p= v*(1.0 - s)
                q= v*(1.0 - s*f)
                t= v*(1.0 - s*(1.0 - f))
                if i mod 6 == 0 then return [v, t, p]
                if i == 1 then return [q, v, p]
                if i == 2 then return [p, v, t]
                if i == 3 then return [p, q, v]
                if i == 4 then return [t, p, v]
                if i == 5 then return [v, p, q]
                # 0 <= i <= 6, so we never come here

class SvgPie
        svgns: "http://www.w3.org/2000/svg"

        constructor: (options)->
                console.log "SvgPie"
                @options = options
                @slices = []
                @progress = 0
                @width = 350
                @height = 350

                @render()

        set: (key, value)->
                console.log 'set'

                if key == 'progress'
                        @progress = value
                @render()

        path: (path, color, data)->
                unless path
                        path = document.createElementNS(@svgns, 'path')
                        @svg.appendChild(path)
                path.setAttribute('style', 'fill-opacity: 0.2;')
                path.setAttribute('fill', color)
                path.setAttribute('stroke', color)
                path.setAttribute('stroke-width', '0')
                path.setAttribute('transform', 'matrix(10,0,0,10,10,10)')
                path.setAttribute('fill-opacity', '1')
                path.setAttribute('d', data)
                return path

        colors: (index, color)->
                # TODO return a variation of a color

        render: ->
                console.log 'render'

                @svg = @options.element
                @svg.setAttribute('style', 'overflow:hidden;position:relative;')
                @svg.setAttribute('height', @width)
                @svg.setAttribute('width', @height)
                @svg.setAttribute('version', '1.1')
                @svg.setAttribute('xmlns', @svgns)

                unless @background
                        @background = @path(@background, @options.background, @options.path)

                if (@options.type == "progress")
                        @options.data = [@progress]
                        @total = 100
                else
                        @total = @options.data.reduce (x, y)-> return x + y
                @angles = @options.data.map (d)=> return (d/@total)*Math.PI*2
                #console.log @total, @angles

                startAngle = 0
                cx = 15.5
                cy = 15.5
                r = 16

                console.log 'svg', @angles.length

                # Draw each angle clipping path
                for value, i in @options.data
                        endAngle = startAngle + @angles[i]
                        console.log startAngle, endAngle, value

                        x1 = cx + r * Math.sin(startAngle)
                        y1 = cy - r * Math.cos(startAngle)
                        x2 = cx + r * Math.sin(endAngle)
                        y2 = cy - r * Math.cos(endAngle)
                        #console.log '---', cx, r, startAngle, Math.sin(startAngle)
                        #console.log "x1, y1, x2, y2", x1, y1, x2, y2
                        x2 = 0 unless x2
                        y2 = 0 unless y2

                        big = if (endAngle - startAngle > Math.PI) then 1 else 0

                        if value == 0
                                data = "M 0,0 Z"
                        else
                                data = "M #{cx},#{cy} L #{x1},#{y1} A #{r},#{r} 0 #{big} 1 #{x2},#{y2} Z"

                        console.log i, data
                        #if @slices.length > 0
                        #        console.log 'slice exists', @slices[i], @svg
                        #        @svg.removeChild(@slices[i])

                        @slices[i] = @path(@slices[i], @options.color, data)
                        console.log @slices[i]

                        startAngle = endAngle
