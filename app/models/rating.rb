# Strange you would think we would have
# something in here.  We should try to
# use this class somehow.
class Rating < ActiveRecord::Base
  belongs_to :user # the user who rated the two pictures
  belongs_to :couple
end
