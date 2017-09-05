class Category < ApplicationRecord

  validates :title, presence: { message: "名称不能为空" }

  has_ancestry

  has_many :products, dependent: :destroy

  before_validation :correct_ancestry

  #取出所有分类
  def self.grouped_data
    self.roots.order("weight desc").inject([]) do |result, parent|
      row = []
      row << parent
      row << parent.children.order("weight desc")
      result << row
    end
  end

  def correct_ancestry
    self.ancestry = nil if self.ancestry.blank?
  end
end
