require 'nokogiri'
require 'json'
require 'pry'

class Crawler
  def parse
    courses = []
    base_url = "http://aps.ntut.edu.tw/course/tw/"
    doc = Nokogiri::HTML(File.read('1031/course.html'))

    doc.css('table tr:not(:first-child)').each do |row|
      datas = row.css('td')

      periods = []
      loc = datas[15].text.strip
      datas[8..14].each_with_index do |d, i|
        d.text.gsub(/[^A-Z\d]/,'').split('').each do |p|
          chars = []
          chars << (i+1).to_s
          chars << p
          chars << loc
          periods << chars
        end
      end

      courses << {
        code: datas[0] && datas[0].text.strip,
        name: datas[1] && datas[1].text.strip,
        stage: datas[2] && datas[2].text.strip,
        credits: datas[3] && datas[3].text.to_i,
        hours: datas[4] && datas[4].text.to_i,
        required: datas[5] && datas[5].text.strip,
        lecturer: datas[7] && datas[7].text.strip,
        periods: periods,
        url: datas[1] && !datas[1].css('a').empty? && "#{base_url}#{datas[1].css('a')[0][:href]}",
      }
    end
    File.open('courses.json', 'w') {|f| f.write(JSON.pretty_generate(courses))}
  end
end

crawler = Crawler.new
crawler.parse
