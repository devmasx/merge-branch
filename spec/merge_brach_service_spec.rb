require_relative '../lib/merge_branch_service'

describe MergeBrachService do
  context "with push" do
    let(:target_branch) { 'develop' }
    let(:inputs) {
      { type: 'push', event: {}, target_branch: target_branch }
    }

    it "#target_branch" do
      service = MergeBrachService.new(inputs)
      expect(service.ensure_target_branch).to eq('develop')
    end
  end

  context "with labeled" do
    let(:label_name) { 'merge in develop' }
    let(:target_branch) { 'develop' }
    let(:event) { { 'action' => 'labeled', 'label' => { 'name' => label_name } } }
    let(:inputs) {
      { type: 'labeled', event: event, target_branch: target_branch, label_name: label_name }
    }

    context "match label" do
      it "#target_branch" do
        service = MergeBrachService.new(inputs)
        expect(service.ensure_target_branch).to eq('develop')
      end
    end

    context "not match label" do
      let(:event) { { 'action' => 'labeled', 'label' => { 'name' => 'other label' } } }

      it "#target_branch" do
        service = MergeBrachService.new(inputs)
        expect(service.ensure_target_branch).to be_nil
      end
    end
  end
end
