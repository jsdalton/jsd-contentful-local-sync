require_relative('../../lib/model_store')
require_relative('../../lib/model')

# Concrete model implementation for test purposes
class SomeModel < Model
  attribute :name, String
  attribute :age, Integer
end

# Concrete model store implementation for test purposes
class SomeModelStore
  include ModelStore
  MODEL_CLS = SomeModel
end

describe ModelStore do
  let(:model_store) { SomeModelStore.new(redis: LocalSyncApp.settings.redis) }
  let(:model_instance) { SomeModel.new(id: 1, name: 'Jack', age: 20) }
  let(:model_instance_2) { SomeModel.new(id: 2, created_at: DateTime.now + 1, name: 'Jill', age: 21) }
  let(:model_instance_3) { SomeModel.new(id: 3, created_at: DateTime.now + 2, name: 'Josh', age: 22) }

  describe '#save' do
    context 'when the model instance is not in the store' do
      it 'saves a model instance to the store' do
        model_store.save(model_instance)
        expect(model_store.get(model_instance.id).id).to eq(model_instance.id)
      end
    end

    context 'when the model instance is already in the store' do
      before :each do
        model_store.save(model_instance)
      end

      it 'updates the model instance' do
        model_instance.name = 'Bob'
        model_store.save(model_instance)
        expect(model_store.get(model_instance.id).id).to eq(model_instance.id)
        expect(model_store.get(model_instance.id).name).to eq(model_instance.name)
      end
    end
  end

  describe '#get' do
    context 'when model instance is in the store' do
      before :each do
        model_store.save(model_instance)
      end

      it 'returns the sync request' do
        expect(model_store.get(model_instance.id).id).to eq(model_instance.id)
      end
    end

    context 'when model instance is not in the store' do
      it 'returns nil' do
        expect(model_store.get('key-does-not-exist')).to be_nil
      end
    end
  end

  describe '#all' do
    context 'when no model instances exist' do
      it 'returns an empty array' do
        expect(model_store.all).to eq([])
      end
    end

    context 'when model instances exist' do
      before :each do
        model_store.save(model_instance)
        model_store.save(model_instance_2)
        model_store.save(model_instance_3)
      end

      it 'returns all model instances' do
        expect(model_store.all.length).to eq(3)
      end
    end
  end

  describe '#latest' do
    before :each do
      model_store.save(model_instance)
      model_store.save(model_instance_2)
      model_store.save(model_instance_3)
    end

    it 'returns the latest' do
      expect(model_store.latest.id).to eq(model_instance_3.id)
    end
  end

  describe '#delete' do
    before :each do
      model_store.save(model_instance)
      model_store.save(model_instance_2)
      model_store.save(model_instance_3)
    end

    it 'removes the instance' do
      model_store.delete(model_instance.id)
      expect(model_store.get(model_instance.id)).to be_nil
    end

    it 'removes the instance from all' do
      model_store.delete(model_instance.id)
      expect(model_store.all.map(&:id)).not_to include(model_instance.id)
    end
  end

  describe '#delete_all' do
    before :each do
      model_store.save(model_instance)
      model_store.save(model_instance_2)
      model_store.save(model_instance_3)
    end

    it 'removes the individual instances' do
      model_store.delete_all
      expect(model_store.get(model_instance.id)).to be_nil
    end

    it 'removes the instances from all' do
      model_store.delete_all
      expect(model_store.all).to eq([])
    end
  end
end
