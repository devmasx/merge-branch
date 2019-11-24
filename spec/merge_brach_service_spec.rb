require_relative '../lib/merge_branch_service'

describe MergeBrachService do
  context "with push" do
    let(:base_branch) { 'develop' }
    let(:inputs) {
      { type: 'push', event: {}, base_branch: base_branch }
    }

    it "#base_branch" do
      service = MergeBrachService.new(inputs)
      expect(service.base_branch).to eq('develop')
    end
  end

  context "with labeled" do
    let(:label_name) { 'merge in develop' }
    let(:base_branch) { 'develop' }
    let(:event) { { 'action' => 'labeled', 'label' => { 'name' => label_name } } }
    let(:inputs) {
      { type: 'labeled', event: event, base_branch: base_branch, label_name: label_name }
    }

    context "match label" do
      it "#base_branch" do
        service = MergeBrachService.new(inputs)
        expect(service.base_branch).to eq('develop')
      end
    end

    context "not match label" do
      let(:event) { { 'action' => 'labeled', 'label' => { 'name' => 'other label' } } }

      it "#base_branch" do
        service = MergeBrachService.new(inputs)
        expect(service.base_branch).to be_nil
      end
    end
  end
end
