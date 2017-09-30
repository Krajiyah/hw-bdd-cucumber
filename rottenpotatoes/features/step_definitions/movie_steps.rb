# Add a declarative step here for populating the DB with movies.

Given /the following movies exist/ do |movies_table|
  Movie.delete_all
  movies_table.hashes.each do |movie|
    Movie.create(movie)
  end
end

And /I am on the RottenPotatoes home page/ do
  visit movies_path
end

Then /(.*) seed movies should exist/ do | n_seeds |
  Movie.count.should be n_seeds.to_i
end

When /I follow "(.*)"/ do |following|
  if following == "Movie Title"
    click_link "title_header"
  elsif following == "Release Date"
    click_link "release_date_header"
  else
    fail "Can't follow #{following}"
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  page.body.should =~ /#{e1}.*#{e2}/m
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  rating_list.split(",").each do |rating|
    rating = "ratings_" + rating
    if uncheck
      uncheck(rating)
    else
      check(rating)
    end
  end
end

When /I submit/ do
  click_button("ratings_submit")
end

Then /I should(nt)? see (.*) movies/ do |nt, rating_list|
  ratings = rating_list.split(",")
  movies = Movie.where(:rating => ratings)
  movies.each do |movie|
    unless nt
      page.should have_content(movie.title)
    else
      page.should have_no_content(movie.title)
    end
  end
end

Then /I should see all the movies/ do
  steps %Q{
    Then I should see G,PG,PG-13,NC-17,R movies
  }
end
