# A class for holding text prompts
class Prompt < ActiveRecord::Base  
  belongs_to :user  
  # gets one random text prompt
  def Prompt.rand
    Prompt.find(:all, :order=>'RANDOM()', :limit=>1).first
  end
end
