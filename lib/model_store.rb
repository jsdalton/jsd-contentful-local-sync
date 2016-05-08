# Module for saving Virtus::Model instances to Redis-backed data store
module ModelStore
  def initialize(redis:)
    @redis = redis
  end

  # Save a model instance to the store
  def save(model_instance)
    store(object_key(model_instance.id), model_instance.attributes)
  end

  # Get a model instance from the store by id
  def get(id)
    fetch(object_key(id))
  end

  # Delete a model instance from the store by id
  def delete(id)
    remove(object_key(id))
  end

  # Get all the model instances in the store
  def all
    fetch_many(index_members)
  end

  def delete_all
    keys = index_members
    return if keys.empty?
    @redis.del(keys)
    destroy_index
  end

  # Get the most recent (by :created_at) model instance from the store
  def latest
    # TODO: Pull from proper created_at index
    all.max_by(&:created_at)
  end

  # Raw dump of object storage internals as Hash
  def export
    Hash[index_members.map { |key| [key, from_json(@redis.get(key))] }]
  end

  # Raw import into object storage. Expects hash mimicking result
  # of export
  def import(data)
    data.each { |key, object| store(key, object) }
  end

  private

  def store(key, object)
    @redis.set key, object.to_json
    save_to_index(key)
  end

  def fetch(key)
    object = @redis.get(key)
    object && to_model(object)
  end

  def remove(key)
    @redis.del key
    remove_from_index(key)
  end

  def fetch_many(keys)
    return [] if keys.empty?
    @redis.mget(keys).map { |key| to_model(key) }
  end

  def index_members
    @redis.smembers(index_key)
  end

  def save_to_index(key)
    @redis.sadd(index_key, key)
  end

  def remove_from_index(key)
    @redis.srem(index_key, key)
  end

  def destroy_index
    @redis.del(index_key)
  end

  def model_cls
    self.class::MODEL_CLS
  end

  def to_model(object)
    model_cls.new(**from_json(object))
  end

  def from_json(object)
    JSON.parse(object, symbolize_names: true)
  end

  def object_key(id)
    "#{namespace}.#{id}"
  end

  def index_key
    "#{namespace}.index"
  end

  def namespace
    "#{model_cls.name.downcase}_store"
  end
end
