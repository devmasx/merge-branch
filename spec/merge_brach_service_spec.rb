require_relative '../lib/services/merge_branch_service'

describe MergeBrachService do
  context "with invalid type" do
    let(:inputs) {
      { type: 'invalid_type', event: {}, target_branch: 'develop' }
    }

    it ".validate_inputs!" do
      expect{ MergeBrachService.validate_inputs!(inputs) }.to raise_error()
    end
  end

  context "with labeled" do
    let(:label_name) { 'merge in develop' }
    let(:target_branch) { 'develop' }
    let(:event) { { 'action' => 'labeled', 'label' => { 'name' => label_name } } }
    let(:inputs) {
      { type: 'labeled', target_branch: target_branch, label_name: label_name }
    }

    context "with valid inputs" do
      it ".validate_inputs!" do
        expect{ MergeBrachService.validate_inputs!(inputs) }.to_not raise_error()
      end
    end

    context "with invalid label name" do
      let(:label_name) { nil }

      it ".validate_inputs!" do
        expect{ MergeBrachService.validate_inputs!(inputs) }.to raise_error()
      end
    end

    context "not match label" do
      let(:event) { { 'action' => 'labeled', 'label' => { 'name' => 'other label' } } }

      it "#valid?" do
        service = MergeBrachService.new(inputs, event)
        expect(service.valid?).to eq(false)
      end
    end
  end
end
