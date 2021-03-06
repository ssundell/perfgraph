define ["jquery", "d3", "q"], ($, d3, q) ->

  class ResponseTimeGraph
    constructor: (canvas, url, currentBuild) ->
      currentBuild ||= []
      height         = canvas.height()
      width          = canvas.width()
      data = q.when $.getJSON url
      data.then (data) ->
        x = d3.scale.linear()
          .domain([0, data.length + 1])
          .range([0, width])

        y = d3.scale.linear()
          .domain([0, 60])
          .range([height, 0])

        xAxis = d3.svg.axis()
          .scale(x)
          .ticks(0)
          .tickSize(0)

        yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(3)
          .tickSize(3)

        graph = d3.select(canvas[0])

        line = d3.svg.line()
          .x((d) -> x(d[0]))
          .y((d) -> y(d[1]))

        graph.selectAll(".current-build")
          .data(currentBuild)
          .enter()
          .append("path")
          .attr("d", (currentBuild, i) -> line([[currentBuild, 0], [currentBuild, -1.5]]))
          .attr("class", "current-build")

        graph.selectAll(".boxplot.min-max")
          .data(data)
          .enter()
          .append("path")
          .attr("d", (d, i) -> line([[i, d.min], [i, d.max]]))
          .attr("class", "boxplot min-max")

        graph.selectAll(".boxplot.percentiles")
          .data(data)
          .enter()
          .append("path")
          .attr("d", (d, i) -> line([[i, d.lowerPercentile], [i, d.upperPercentile]]))
          .attr("class", "boxplot percentiles")
          .on("click", (d) -> page "/reports/#{d.build}")

        graph.selectAll(".boxplot.median")
          .data(data)
          .enter()
          .append("path")
          .attr("d", (d, i) -> line([[i - 0.2, d.median], [i + 0.2, d.median]]))
          .attr("class", "boxplot median")

        graph.append("g")
          .attr("class", "axis")
          .call(yAxis)

        graph.append("g")
          .attr("class", "axis")
          .attr("transform", "translate(0, #{height})")
          .call(xAxis)
