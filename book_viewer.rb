require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

# Before Filters:

before do 
  @contents = File.readlines("data/toc.txt")
end

# Routes:

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover?(number)

  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end

get "/search" do
  def each_chapter 
    @contents.each_with_index do |title, number|
      number += 1
      text = File.read("data/chp#{number}.txt")
      yield(number, title, text)
    end
  end
  
  def chapters_matching(query)
    results = []
    return results if !query || query.empty?
  
    each_chapter do |number, title, text|
      if text.include?(query)
        text = text.split("\n\n")
        par_num_text_pair = []

        text.each_with_index do |paragraph, index|
          if paragraph.include?(query)
            par_num_text_pair << [index, paragraph]
          end
        end
        results << {number: number, name: title, paragraphs: par_num_text_pair}
      end 
    end
    results
  end

  @results = chapters_matching(params[:query])
  erb :search
end

# Helpers:

helpers do 
  def in_paragraphs(chapter_content)
    arrayed_pars = chapter_content.split("\n\n")

    arrayed_pars.each_with_index.map do |par, index| 
      "<p id=paragraph#{index}>#{par}</p>"
    end.join
  end

  def bold_query_matches(query, text)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end