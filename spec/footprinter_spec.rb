# coding: utf-8
require 'spec_helper'
require 'acts_as_footprintable/footprinter'

describe ActsAsFootprintable::Footprinter do

  it "should not be a footprinter" do
    expect(NotUser).not_to be_footprinter
  end

  it "should be a footprinter" do
    expect(User).to be_footprinter
  end

  describe "ユーザーのアクセス履歴を" do
    before do
      @user = User.create!(:name => "user")
      (1..5).each do |index|
        footprintable = Footprintable.create!(:name => "footprintable#{index}")
        second_footprintable = SecondFootprintable.create!(:name => "second_footprintable#{index}")
        3.times do
          footprintable.leave_footprints @user
          second_footprintable.leave_footprints @user
        end
      end
    end

    context "対象のモデル毎に" do
      it "取得できること" do
        expect(@user.access_histories_for(Footprintable).count).to eq 5
        expect(@user.access_histories_for(Footprintable).map{|footprint| footprint.footprintable.name}).to eq (1..5).to_a.reverse.map{|index| "footprintable#{index}"}
      end

      it "件数を絞り込めること" do
        expect(@user.access_histories_for(Footprintable, 3).count).to eq 3
        expect(@user.access_histories_for(Footprintable, 3).map{|footprint| footprint.footprintable.name}).to eq (3..5).to_a.reverse.map{|index| "footprintable#{index}"}
      end
    end

    context "全てのモデルを通じて" do
      it "取得できること" do
        expect(@user.access_histories.count).to eq 10
        footprintable_names = (1..5).to_a.reverse.inject([]) do |results, index|
          results.push "second_footprintable#{index}"
          results.push "footprintable#{index}"
          results
        end
        expect(@user.access_histories.map{|footprint| footprint.footprintable.name}).to eq footprintable_names
      end

      it "件数を絞り込める事" do
        expect(@user.access_histories(3).count).to eq 3
      end
    end
  end
end
