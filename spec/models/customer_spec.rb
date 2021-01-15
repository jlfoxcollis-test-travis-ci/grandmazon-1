require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'validations' do
    it 'name has to be a string' do
      @user = create(:user, role: 1)

      customer = Customer.new(first_name: 1, last_name: 'bob', user: @user)
      customer1 = Customer.new(first_name: "x", last_name: 1, user: @user)
      expect(customer.save).to eq(false)
      expect(customer1.save).to eq(true)
    end
  end

  describe 'relationships' do
    it { should have_many :invoices }
    it { should belong_to :user}
    it { should have_many(:transactions).through(:invoices) }
    it { should have_many(:merchants).through(:invoices) }
    it { should have_many(:invoice_items).through(:invoices) }
    it { should have_many(:items).through(:invoice_items)}
  end

  describe 'instance methods' do
    before :each do
      @user = create(:user, role: 1)
      @merchant = create(:merchant, user: @user)

      @user1 = create(:user, role: 1)
      @customer_1 = create(:customer, user: @user1)
      @user2 = create(:user, role: 1)
      @customer_2 = create(:customer, user: @user2)
      @user3 = create(:user, role: 1)
      @customer_3 = create(:customer, user: @user3)
      @user4 = create(:user, role: 1)
      @customer_4 = create(:customer, user: @user4)
      @user5 = create(:user, role: 1)
      @customer_5 = create(:customer, user: @user5)
      @user6 = create(:user, role: 1)
      @customer_6 = create(:customer, user: @user6)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      Customer.all.each do |customer|
        create_list(:invoice, 1, customer: customer, merchant: @merchant)
      end

      customer_list = [@customer_1, @customer_2, @customer_3, @customer_4, @customer_5, @customer_6]

      create_list(:transaction, 10, invoice: @customer_5.invoices.first, result: 0)

      customer_list.size.times do |i|
        create_list(:transaction, (i+1), invoice: customer_list[i].invoices.first, result: 1)
      end
    end

    it '#successful_purchases' do
      expect(@customer_1.successful_purchases).to eq(1)
      expect(@customer_3.successful_purchases).to eq(3)
      expect(@customer_2.successful_purchases).to eq(2)
      expect(@customer_5.successful_purchases).to eq(5)
    end
  end

  describe 'class methods' do
    before :each do
      @user = create(:user, role: 1)
      @merchant = create(:merchant, user: @user)

      @user1 = create(:user, role: 1)
      @customer_1 = create(:customer, user: @user1)
      @user2 = create(:user, role: 1)
      @customer_2 = create(:customer, user: @user2)
      @user3 = create(:user, role: 1)
      @customer_3 = create(:customer, user: @user3)
      @user4 = create(:user, role: 1)
      @customer_4 = create(:customer, user: @user4)
      @user5 = create(:user, role: 1)
      @customer_5 = create(:customer, user: @user5)
      @user6 = create(:user, role: 1)
      @customer_6 = create(:customer, user: @user6)

      Customer.all.each do |customer|
        create_list(:invoice, 1, customer: customer, merchant: @merchant)
      end

    end
    it '::top_five_customers' do
      customer_list = [@customer_1, @customer_2, @customer_3, @customer_4, @customer_5, @customer_6]

      create_list(:transaction, 10, invoice: @customer_5.invoices.first, result: 0)

      customer_list.size.times do |i|
        create_list(:transaction, (i+1), invoice: customer_list[i].invoices.first, result: 1)
      end

      expect(Customer.top_five_customers).to eq([@customer_6, @customer_5, @customer_4, @customer_3, @customer_2])
    end
  end

end
