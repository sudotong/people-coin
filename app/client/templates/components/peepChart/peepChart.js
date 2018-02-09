Template['components_peepChart'].onRendered(function() {

    let allTrades = this.data.peep.allTrades;
    let ctx = $("#peepChart");
    let i = 1;
    let data = allTrades.map(function(yPoint){
        return {
            x: i++,
            y: yPoint
        }
    });
    let myLineChart = new Chart(ctx, {
        type: 'scatter',
        data: {
            datasets: [{
                data: data,
                pointBackgroundColor: "rgba(51, 122, 183)",
                borderColor: "rgba(51, 122, 183)",
                pointBorderWidth: 0,
                pointRadius: 2
            }]
        },
        options:{
            legend: {
                display: false
            },
            scales: {
                xAxes: [{
                    display: false
                }]
            }
        }
    });

});
