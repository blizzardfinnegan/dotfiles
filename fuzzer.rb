#!/usr/bin/env ruby
# Disallows modifying string literals in code
# frozen_string_literal: true

#CLI Argument parsing
require 'slop'

#Web interaction libraries
require 'rubygems'
require 'mechanize'

#Instantiate an agent, and set the user-agent to spoof that of a Windows Chrome device
agent = Mechanize.new;
agent.user_agent_alias = "Windows Chrome";

#Parse options from CLI
opts = Slop.parse do |o|
  o.string '-a', '--custom-auth', "Custom authentication mode";
  o.string 'd', 'discover', "Set mode to discover; requires address to connect to", default: "http://localhost";
end

# opts[:custom_auth] stores the custom authentication mode
# opts[:discover] stores the address passed in at runtime


# If the run doesn't say it is a DVWA instance, don't do anything special
if opts[:custom_auth] != "dvwa"; 

  #Get page passed in at terminal, print the body of the page, exit early
  page = agent.get(opts[:discover]);
  p page.body;
  exit; 
end;

## From here, we can assume that we have the dvwa flag, and can act accordingly
#Go to setup
setup_page = agent.get(opts[:discover] + "/setup.php") do |page|
  #Search the page for the form (there should only be one)
  setup_result = page.form() do |form|
    #Press the button (defaults to the first button; since the form only has one button, this is fine)
    form.click_button;
  end.submit;
end;

#Go back to the opening page
login_page = agent.get(opts[:discover]) do |page|

  # Get the form from the page
  login_form = page.form(); 

  #Fill in the form with the known information
  login_form['username'] = 'admin';
  login_form['password'] = 'password';

  #submit form
  homepage = login_form.click_button;

  #Go to security page
  security_page = homepage.link(href:"security.php").click;

  #Find, modify, and submit drop-down form
  security_settings_form = security_page.forms()[0];
  security_settings_form['security'] = 'low';
  updated_security_page = security_settings_form.click_button;

  #Go back to home page
  updated_homepage = updated_security_page.link(href:".").click;
  
  #Print to std.out
  #REMOVE ME AFTER SUBMISSION 1
  p updated_homepage.body;
end

