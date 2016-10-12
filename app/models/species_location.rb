class SpeciesLocation < ActiveRecord::Base
  belongs_to :species

  after_save do
    if self.removed and !self.removal_date then
      self.removal_date = DateTime.now
      self.save()
    elsif !self.removed and self.removal_date then
      self.removal_date = null
      self.save()
    end
  end
end
