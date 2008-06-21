# The User class holds information about
# a person who has added couple rater.
# We hold their name, facebook id, and
# some preferences such as do they want
# to see question marks.  Each user has
# many picture including one active picture.
# We use these pictures to create Couples.
# A user also is associated with many networks
# where he can rate the couplings of other
# users.
class User < ActiveRecord::Base
  has_many :pictures #pictures loaded up
  has_many :ratings # the ones he/she created
  has_and_belongs_to_many :networks
  has_many :prompts

  # Gender column
  MALE = true
  FEMALE = false

  # Tries to find a user with the fb_user's fb_id.
  # If the user does not exist, creates a user with
  # the profile picture as the current picture
  # and adds in the networks of the current fb_user.
  # Returns the couple rater user.
  def User.find_or_create(fb_user_id, fb_user_sex, fb_first_name, fb_last_name, affiliation_list, session_key=nil)
    if(exists?(:fb_id=>fb_user_id))
      user = find_by_fb_id(fb_user_id)
    else
      male = (fb_user_sex == 'male')
      user = create({:fb_id=>fb_user_id, :gender=>male,
		     :first_name=>fb_first_name, :last_name=>fb_last_name,
		     :with_men=>true, :with_women=>true,
			:friends_can_see_my_matches=>true,
			:non_friends_can_see_my_matches=>true,
			:session_key=>session_key, :see_question_marks=>true})
      user.update_picture(fb_user_id)
      user.update_networks(affiliation_list)
    end
    user
  end

  # If the picture exists, we switch it to the
  # the users active picture.  Otherwise, we
  # create the picture and make it the active
  # picture.
  # Special case: If the user's active picture is a
  # profile_pic?, we get rid of it by switching
  # the id of the new picture to the id for the
  # profile picture.  We are worried about
  # duplicates because a profile picture does not
  # have a unique id associated with it.  Instead
  # the id is really the user's facebook id which
  # associates with his/her active facebook photo.
  # We cannot tell what photo that is so we get
  # rid of it to avoid duplicates.  
  # In doing so we blindly transfer information 
  # between two possible different photos.
  # A possible solution to this issue is to never use the
  # profile picture in the first place.
  def update_picture(fb_pid) 
    if(!picture_id.nil? and picture.profile_pic?)
        picture.update_attribute(:fb_id,fb_pid)
    else
        pic = Picture.find_or_create(fb_pid)
        pictures << pic
	update_attribute(:picture_id, pic.id)
    end	
  end

  # Updates the user's networks from the given 
  # Facebooker Affiliations list.
  def update_networks(affiliation_list)
      affiliation_list.each { |affiliation|
        network = Network.find_or_create(affiliation.nid,affiliation.name)
        networks << network
      }
  end	

  # gets ya a couple of peeple who have genders fitting what's in the browse form
  # Returns a list of two User objects who meet the gender parameters from the html form
  def User.findy(gendy)
    coup = nil
    if gendy == "straight"
      persona = findies(MALE, "with_women")
      if(persona.nil?)
        return nil
      end
      persona_dos = findies(FEMALE, "with_men")
      return nil if persona_dos == nil
      coup = [persona, persona_dos]
    elsif gendy == "gay"
      persona = findies(MALE, "with_men")
      if(persona.nil?)
	return nil
      end
      persona_dos = findiesId(MALE, "with_men", persona.id)
      return nil if persona_dos == nil
      coup = [persona, persona_dos]
    elsif gendy == "lesbian"
      persona = findies(FEMALE, "with_women")
      if(persona.nil?)
	return nil
      end
      persona_dos = findiesId(FEMALE,"with_women",persona.id)
      return persona_dos if persona_dos == nil
      coup = [persona, persona_dos]
    else
      # We need to make sure that if there can be a couple, one is returned.  Hence the complications.
      persona = User.find(:all, :conditions=>['with_men=? OR with_women=?', true, true]).rand
      return nil if persona.nil?
      if persona.with_men && ((rand < 0.5) || (persona.with_women == false))
        if persona.gender == MALE
          coup = selectMatch(persona, MALE, "with_men", "straight", "lesbian") # unless there are no other gay/bi men, returns 2 men
        else
          coup = selectMatch(persona, MALE, "with_women", "lesbian", "gay") # unless there are no straight/bi men returns 1 man + 1 woman 
        end
      else
        if persona.gender == MALE
          coup = selectMatch(persona, FEMALE, "with_men", "lesbian", "gay") # unless there are no straight/bi women returns 1 man + 1 woman
        else
          coup = selectMatch(persona, FEMALE, "with_women", "straight", "gay") # unless there are no other lesbian/bi women returns 2 womenn
        end
      end
          
      # coup = find(:all, :order=>'RANDOM()', :limit=>2)
    end
    return coup # find(:all, :order=>'RANDOM()', :limit=>2)
  end

  # Takes an array of users, and a string indicating orientation
  # Returns all users from the array who could be in a couple of the given orientation
  # Does not modify the given array
  def User.findyPeopleFromOrientation(users_to_use, orientation)
    return [] if users_to_use == nil || users_to_use.empty?
    useme = users_to_use.clone
    if(orientation == "gay")
      users_to_use.each {|n| useme.delete n if !n.gender || !n.with_men } # must use users_to_use.each or else .each will skip an item in the list every time something is deleted.
    elsif(orientation == "straight")
      users_to_use.each {|current| useme.delete current if (current.gender && !current.with_women) || (!current.gender && !current.with_men) }
    elsif(orientation == "lesbian")
      users_to_use.each {|n| useme.delete n if n.gender || !n.with_women }
    else
      users_to_use.each {|n| useme.delete n if !(n.with_men || n.with_women) }
    end
    return useme
  end

  # Takes an array of Users, a single User for whom we are seeking a match, and a string representing orientation
  # Returns an array containing persona and a second user from the given array who could be with persona
  # in a match with the given orientation
  # precondition: the user passed in as a parameter must be able to be in a couple with the given orientation
  # Does not modify the given array
  def User.findyMatchByOrientation(users_to_use, persona, orientation)
    return nil if users_to_use == nil || users_to_use.empty?
    persona_dos = nil
    useme = users_to_use.clone
    useme.delete persona  #### NOOOO DUPLICATES!!!
    pool = User.findyPeopleFromOrientation(useme, orientation)
    return nil if pool.empty?
    manly = orientation == "gay"
    ladylike = orientation == "lesbian"
    if(manly || ladylike)
      if persona == nil || (manly && (!persona.gender || !persona.with_men)) || (ladylike && (persona.gender || !persona.with_women))
        persona = pool.rand
        pool.delete persona
      end
      persona_dos = pool.rand
    elsif(orientation == "straight")
      if persona == nil || (persona.gender && !persona.with_women) || (!persona.gender && !persona.with_men)
        persona = pool.rand
        pool.delete persona
      end
      useme = pool.clone
      if(persona.gender == MALE)
        useme.each {|n| pool.delete n if n.gender }
        persona_dos = pool.rand
      else
        useme.each {|n| pool.delete n if !n.gender }
        persona_dos = pool.rand
      end
    else      # If anyone can be returned, someone will be returned.  I promise.
       return helpyFindyMatchByOrientation(users_to_use, persona, false, false, false)
    end
    return [persona, persona_dos] if persona_dos != nil
    return nil
  end

  # Helper method for findyMatchByOrientation, for when a search 
  # for a couple of a random orientation fails on the first try.
  # Takes an array of Users to choose a match from, and a persona to match the new guy up with
  # Returns an array with persona and the new guy; it is not guaranteed that the persona you pass in will end up in the couple
  def User.helpyFindyMatchByOrientation(users_to_use, persona, triedGay, triedLesbian, triedStraight)
    return nil if(triedGay && triedStraight && triedLesbian)
    pool = users_to_use.clone
    persona_dos = nil
    if(!triedGay && ((triedLesbian && triedStraight) || (!triedStraight && triedLesbian && rand > 0.5) || (!triedLesbian && triedStraight && rand > 0.5) || (!triedLesbian && !triedStraight && rand > 0.66)))
      users_to_use.each {|n| pool.delete n if !n.gender || !n.with_men }
      persona = pool.rand if persona == nil || !persona.gender || !persona.with_men
      pool.delete persona
      persona_dos = pool.rand
      return [persona, persona_dos] if persona_dos != nil
      return helpyFindyMatchByOrientation(users_to_use, persona, true, triedLesbian, triedStraight)
    elsif(!triedStraight && (triedLesbian || (!triedLesbian && rand > 0.5)))
      pool = findyPeopleFromOrientation(users_to_use, "straight")
      return helpyFindyMatchByOrientation(users_to_use, persona, triedGay, triedLesbian, true) if pool.empty?
      persona = pool.rand
      pool.delete persona
      useme = pool.clone
      if persona.gender
        useme.each {|n| pool.delete n if n.gender || !n.with_men }
      else
        useme.each {|n| pool.delete n if !n.gender || !n.with_women }
      end
      persona_dos = pool.rand
      return [persona, persona_dos] if persona_dos != nil
      return helpyFindyMatchByOrientation(users_to_use, persona, triedGay, triedLesbian, true)
    else
      pool = findyPeopleFromOrientation(users_to_use, "lesbian")
      persona = pool.rand if persona == nil || persona.gender || !persona.with_women
      pool.delete persona
      persona_dos = pool.rand
      return [persona, persona_dos] if persona_dos != nil
      return helpyFindyMatchByOrientation(users_to_use, persona, triedGay, true, triedStraight)
    end
  end

  # Tries to find someone to be with persona; if such a person is found, returns persona and the
  # other User in an array.  Else returns nil
  def User.selectMatch(persona, gender, with, alt1, alt2)
    persona2 = findiesId(gender, with, persona.id)
    coup = nil
    if persona2 == nil
      coup = User.findy(alt1)
      if coup == nil
        return User.findy(alt2)
      else
        return coup
      end
    else
      coup = [persona, persona2]
    end
    return coup
  end


  # findys one person with the given gender
  # gender is the boolean value representing the gender of the person you want to find
  # with is the string stating which gender the given person must have agreed to appear with
  # Note: Pulls out all values with a given gender and chooses one at 
  # random.  Ruby is shiny.
  def User.findies(gender, with)
    if with == "with_men"
      return User.find(:all, :conditions=>['gender=? AND with_men=?', gender, MALE]).rand
    else
      return User.find(:all, :conditions=>['gender=? AND with_women=?', gender, MALE]).rand
    end
  end

  # Finds a person of the given gender that does not have the given id
  def User.findiesId(gender, with, not_id)
    if with == "with_men"
      return User.find(:all, :conditions=>['gender=? AND id<>? AND with_men<>?', gender, not_id, FEMALE]).rand
    else
      return User.find(:all, :conditions=>['gender=? AND id<>? AND with_women<>?', gender, not_id, FEMALE]).rand
    end
  end


  # Returns the active picture of the user.
  def picture
    pictures.find(picture_id)
  end

  # Returns the intersection of networks
  def networks_with(other)
    networks & other.networks
  end

  # guesses the sexual orientation of the user
  def default_gender
    if(with_men and with_women)
        "bi"
    elsif(gender and with_men)
        "gay"
    elsif(!gender and with_women)
        "lesbian"
    else
        "straight"
    end
  end

  # Called when a user uninstalls
  def kill
    ratings.each { |r|
	 coup = r.couple
	 r.destroy
	 coup.refresh # keep rating cache up to date
    }

    pictures.each { |pic| 
		pic.couples.each { |coup| 
				coup.ratings.destroy_all
				coup.destroy
				}
		}
    pictures.destroy_all
    destroy
  end
 
  # Finds any network with two users without respect for
  # gender issues.
  def find_a_network_with_two_users
    networks.detect { |net| !net.users.findy("bi").nil? }
  end

  # sometimes, Ruby uses Object.id method instead of the User's id, so...
  def getId
    id
  end

  # Flips the boolean attribute for question marks
  def flip_question_mark_setting
    update_attribute(:see_question_marks,!see_question_marks)
  end
end
