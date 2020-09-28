require 'spec_helper'

describe 'DateAsString' do
  let(:today) { Date.today }
  let(:tomorrow) { today + 1.day }
  let(:yesterday) { today - 1.day }
  let(:new_years_day_1990) { Date.new(1990, 1, 1) }

  describe '.parse_date(date)' do
    subject { DateAsString.parse_date date_arg }

    context 'when provided with a Date' do
      let(:date_arg) { new_years_day_1990 }

      it { is_expected.to eq "01/01/1990" }
    end

    describe 'handling invalid arguments' do
      context "argument is a String" do
        let(:date_arg) { 'abc' }

        it { is_expected.to eq nil }
      end
    end
  end

  describe ".parse_string(string)" do
    subject { DateAsString.parse_string date_string_arg }

    context "format -> 't+#'" do
      let(:date_string_arg) { "t+1" }

      it { is_expected.to eq tomorrow }
    end

    context "format -> 't-#'" do
      let(:date_string_arg) { "t-1" }

      it { is_expected.to eq yesterday }
    end

    context "format -> 't'" do
      let(:date_string_arg) { "t" }

      it { is_expected.to eq today }
    end

    context "format -> '######'" do
      let(:date_string_arg) { "010190" }

      it { is_expected.to eq new_years_day_1990 }
    end

    context "format -> '########'" do
      let(:date_string_arg) { "01011990" }

      it { is_expected.to eq new_years_day_1990 }
    end

    context "format -> '##/##/##'" do
      let(:date_string_arg) { "01/01/90" }

      it { is_expected.to eq new_years_day_1990 }
    end

    context "format -> '##/##/####'" do
      let(:date_string_arg) { "01/01/1990" }

      it { is_expected.to eq new_years_day_1990 }
    end

    describe 'handling invalid arguments' do
      context "argument is a String" do
        let(:date_string_arg) { 'abc' }

        it { is_expected.to eq nil }
      end
    end
  end
end
