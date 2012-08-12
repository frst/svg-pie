class SvgPie
        svgns: "http://www.w3.org/2000/svg"
        cx: 15.5
        cy: 15.5
        r: 16

        constructor: (options)->
                #console.log "SvgPie"
                @options = options
                @slices = []
                @progress = 0
                @width = 350
                @height = 350

                @setSvg()
                @setBackground()
                @render()

        set: (key, value)->
                #console.log 'set'

                if key == 'progress'
                        @progress = value
                @render()

        path: (path, color, data)->
                return path

        setSvg: ->
                @svg = d3.select(@options.element).append('svg:svg')
                        .attr('style', 'overflow:hidden;position:relative;')
                        .attr('width', @width)
                        .attr('height', @height)

        setBackground: ->
                @svg.append("svg:path")
                        .attr('style', 'fill-opacity: 0.2;')
                        .attr('fill', @options.background)
                        .attr('stroke', @options.background)
                        .attr('stroke-width', '0')
                        .attr('transform', 'matrix(10,0,0,10,10,10)')
                        .attr('fill-opacity', '1')
                        .attr('d', @options.path)

        arcData: (start, end)->
                x1 = (@cx + @r * Math.sin(start)) or 0
                y1 = (@cy - @r * Math.cos(start)) or 0
                x2 = (@cx + @r * Math.sin(end)) or 0
                y2 = (@cy - @r * Math.cos(end)) or 0

                big = if (end - start > Math.PI) then 1 else 0

                return "M #{@cx},#{@cy} L #{x1},#{y1} A #{@r},#{@r} 0 #{big} 1 #{x2},#{y2} Z"

        render: ->

                if (@options.type == "progress")
                        @options.data = [@progress]
                        @options.colors = [@options.color]
                        @total = 100
                else
                        @total = @options.data.reduce (x, y)-> return x + y

                # Calculate each pie slice in radians
                @angles = @options.data.map (d)=> return (d/@total)*Math.PI*2

                startAngle = 0

                # Draw each angle clipping path
                for value, i in @options.data
                        endAngle = startAngle + @angles[i]

                        data = @arcData(startAngle, endAngle)
                        color = @options.colors[i]

                        @defs = @svg.append('svg:defs') unless @defs

                        clipPath = @defs.append('svg:clipPath')
                                .attr('id', "clip-#{@options.id}-#{i}")
                                .append('svg:path')
                                .attr('d', data)

                        path = @svg.append('svg:path')
                                .attr('clip-path', "url(#clip-#{@options.id}-#{i})")
                                .attr('d', @options.path)
                                .attr('id', "path-#{@options.id}-#{i}")
                                .attr('style', 'fill-opacity: 1;')
                                .attr('fill', color)
                                .attr('stroke', color)
                                .attr('stroke-width', '0')
                                .attr('transform', 'matrix(10,0,0,10,10,10)')
                                .attr('fill-opacity', '1')

                        startAngle = endAngle
