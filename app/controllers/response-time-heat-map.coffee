define ["jquery", "d3"], ($, d3) ->

  class ResponseTimeHeatMap
    constructor: (@elem, @url, @historyLength) ->
      @height = @elem.height()
      @width  = @elem.width()

    setHistoryLength: (historyLength) ->
      @historyLength = historyLength

    update: () ->
      $.getJSON "#{@url}/#{@historyLength}", (data) =>
        lastBuild  = d3.max(data.buckets, (d) -> d.build)
        firstBuild = d3.min(data.buckets, (d) -> d.build)
        maxTime = d3.max(data.buckets, (d) -> d.bucket)

        x = d3.scale.ordinal()
          .domain([firstBuild..lastBuild])
          .rangeBands([0, @width], 0.1)

        y = d3.scale.linear()
          .domain([0, Math.max(maxTime, 10)])
          .range([@height, 0])
          .nice()

        z = d3.scale.sqrt()
          .domain([0, d3.max data.buckets, (d) -> d.count])
          .range(["lightblue", "black"])

        xAxis = d3.svg.axis()
          .scale(x)
          .tickSize(0)

        yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .ticks(3)
          .tickSize(3)

        graph = d3.select(@elem[0])

        graph.selectAll(".axis").remove()

        graph.append("g")
          .attr("class", "y axis")
          .call(yAxis)

        graph.select(".y.axis")
          .append("text")
          .attr("class", "y label")
          .attr("text-anchor", "end")
          .attr("y", -36)
          .attr("dy", ".75em")
          .attr("transform", "rotate(-90)")
          .text("response time [s]")

        graph.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0, #{@height})")
          .call(xAxis)
          .selectAll("text")
          .attr("class", "build")
          .classed("hidden", (build) -> build not in [firstBuild, lastBuild])

        graph.select(".x.axis")
          .append("text")
          .attr("class", "x label")
          .attr("text-anchor", "end")
          .attr("x", @width + 7)
          .attr("y", 20)
          .text("build #")

        labels    = graph.selectAll(".x.axis .build")
        showLabel = (d) ->
          labels.classed("hidden", (build) -> build not in [firstBuild, lastBuild, d.build])

        tiles = graph.selectAll(".tile")
          .data(data.buckets)
          .on("mouseover", showLabel)
          .attr("x",      (d) -> x(d.build))
          .attr("y",      (d) -> y(d.bucket))
          .attr("width",  (d) -> x.rangeBand())
          .attr("height", (d) -> y(d.bucket) - y(d.bucket + data.bucketSize))
          .style("fill",  (d) -> z(d.count))
          .on("click",    (d) -> page "/reports/#{data.project}/#{data.testCase}/#{d.build}")

        tiles.enter()
          .append("rect")
          .attr("class", "tile")
          .on("mouseover", showLabel)
          .attr("x",      (d) -> x(d.build))
          .attr("y",      (d) -> y(d.bucket))
          .attr("width",  (d) -> x.rangeBand())
          .attr("height", (d) -> y(d.bucket) - y(d.bucket + data.bucketSize))
          .style("fill",  (d) -> z(d.count))
          .on("click",    (d) -> page "/reports/#{data.project}/#{data.testCase}/#{d.build}")

        tiles.exit().remove()
