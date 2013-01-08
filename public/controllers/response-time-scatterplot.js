(function() {

  define(["jquery", "d3"], function($, d3) {
    var ResponseTimeScatterPlot;
    return ResponseTimeScatterPlot = (function() {

      function ResponseTimeScatterPlot(elem, url, markSize) {
        var height, width,
          _this = this;
        this.elem = elem;
        height = this.elem.height();
        width = this.elem.width();
        $.getJSON(url, function(data) {
          var graph, sample, sampleFormatter, showSample, x, xAxis, y, yAxis;
          data = {
            samples: data,
            maxElapsedTimeInBuild: 7
          };
          sampleFormatter = function(d) {
            d.elapsedTimeStr = d.elapsedTime.toFixed(3);
            return d;
          };
          $(".tops .response-time").render(data.samples.map(sampleFormatter), {
            label: {
              href: function() {
                return this.label;
              }
            }
          });
          x = d3.scale.linear().domain([
            d3.min(data.samples, function(d) {
              return d.timeSinceStart;
            }), d3.max(data.samples, function(d) {
              return d.timeSinceStart;
            })
          ]).range([0, width]).nice();
          y = d3.scale.sqrt().domain([0, Math.max(data.maxElapsedTimeInBuild, 5)]).range([height, 0]).nice();
          sample = $('.report .sample');
          showSample = function(d) {
            var date;
            date = new Date(d.timeStamp * 1000);
            sample.find('.timeStamp').text("" + date);
            sample.find('.elapsedTime').text("" + d.elapsedTimeStr + " s");
            sample.find('.responseCode').text(d.responseCode);
            sample.find('.bytes').text("" + d.bytes + " B");
            return sample.find('.label').text(d.label).attr("href", d.label);
          };
          xAxis = d3.svg.axis().scale(x).ticks(6);
          yAxis = d3.svg.axis().scale(y).orient("left").ticks(6);
          graph = d3.select(_this.elem[0]);
          graph.selectAll(".mark").data(data.samples).enter().append("circle").attr("class", function(d) {
            if (d.failed) {
              return "mark failed";
            } else {
              return "mark passed";
            }
          }).attr("cx", function(d) {
            return x(d.timeSinceStart);
          }).attr("cy", function(d) {
            return y(d.elapsedTime);
          }).attr("r", markSize).on("mouseover", showSample);
          graph.append("g").attr("class", "axis").call(yAxis);
          return graph.append("g").attr("class", "axis").attr("transform", "translate(0, " + height + ")").call(xAxis);
        });
      }

      return ResponseTimeScatterPlot;

    })();
  });

}).call(this);
