require 'spec_helper.rb'

describe GoogleVisualr::BaseChart do
  before { Daru::View.plotting_library = :googlecharts }
  let(:query_string) {'SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8'}
  let(:data_spreadsheet) {'https://docs.google.com/spreadsheets/d/1XWJLkAwch'\
              '5GXAt_7zOFDcg8Wm8Xv29_8PWuuW15qmAE/gviz/tq?gid=0&headers='\
              '1&tq=' << query_string}
  let(:plot_spreadsheet) {
    Daru::View::Plot.new(
      data_spreadsheet,
      {type: :column, width: 800}
    )
  }
  let(:data) do
    [
      ['Year'],
      ['2013'],
    ]
  end
  let(:column_chart) {
    Daru::View::Plot.new(data, type: :column)
  }

  describe "#query_response_function_name" do
    it "should generate unique function name to handle query response" do
      func = plot_spreadsheet.chart.query_response_function_name('i-d')
      expect(func).to eq('handleQueryResponse_i_d')
    end
  end

  describe "#to_js_spreadsheet" do
    it "generates valid JS of the chart when "\
       "data is imported from google spreadsheets" do
      js = plot_spreadsheet.chart.to_js_spreadsheet(data_spreadsheet, 'id')
      expect(js).to match(/<script type='text\/javascript'>/i)
      expect(js).to match(/google.load\(/i)
      expect(js).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(js).to match(/gid=0&headers=1&tq=/i)
      expect(js).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(js).to match(/var data_table = response.getDataTable/i)
      expect(js).to match(
        /google.visualization.ColumnChart\(document.getElementById\(\'id\'\)/
      )
      expect(js).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
  end

  describe "#draw_js_spreadsheet" do
    it "draws valid JS of the chart when "\
       "data is imported from google spreadsheets" do
      js = plot_spreadsheet.chart.draw_js_spreadsheet(data_spreadsheet, 'id')
      expect(js).to match(/https:\/\/docs.google.com\/spreadsheets/i)
      expect(js).to match(/gid=0&headers=1&tq=/i)
      expect(js).to match(/SELECT A, H, O, Q, R, U LIMIT 5 OFFSET 8/i)
      expect(js).to match(/var data_table = response.getDataTable/i)
      expect(js).to match(
        /google.visualization.ColumnChart\(document.getElementById\(\'id\'\)/
      )
      expect(js).to match(/chart.draw\(data_table, \{width: 800\}/i)
    end
  end

  describe "#draw_chart_js" do
    subject(:js) { column_chart.chart.draw_chart_js('id') }
    it "adds correct data" do
      expect(js).to match(/var chart = null;/)
      expect(js).to match(
        /data_table.addColumn\({"type":"string","label":"Year"}\)/
      )
      expect(js).to match(/data_table.addRow\(\[{v: "2013"}\]\)/)
    end
    it "adds correct listener" do
      column_chart.chart.add_listener('ready', "alert('hi');")
      expect(js).to match(
        /google.visualization.events.addListener\(chart, 'ready', function \(e\) {/
      )
      expect(js).to match(/alert\('hi'\);/)
    end
    it "generates the valid chart script" do
      expect(js).to match(/new google.visualization.DataTable/)
      expect(js).to match(/new google.visualization.ColumnChart/)
      expect(js).to match(/chart.draw\(data_table, {}\)/)
    end
  end
end