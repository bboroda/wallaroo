use "collections"
use "wallaroo/core"
use "wallaroo/data_channel"
use "wallaroo/ent/network"
use "wallaroo/ent/recovery"
use "wallaroo/topology"


interface DataReceiversSubscriber
  be data_receiver_added(sender_name: String, boundary_step_id: U128,
    dr: DataReceiver)

actor DataReceivers
  let _auth: AmbientAuth
  let _worker_name: String

  var _initialized: Bool = false

  let _data_receivers: Map[BoundaryId, DataReceiver] =
    _data_receivers.create()
  var _data_router: DataRouter =
    DataRouter(recover Map[U128, Consumer] end)
  let _subscribers: SetIs[DataReceiversSubscriber tag] = _subscribers.create()

  new create(auth: AmbientAuth, worker_name: String,
    is_recovering: Bool = false)
  =>
    _auth = auth
    _worker_name = worker_name
    if not is_recovering then
      _initialized = true
    end

  be subscribe(sub: DataReceiversSubscriber tag) =>
    _subscribers.set(sub)

  fun _inform_subscribers(b_id: BoundaryId, dr: DataReceiver) =>
    for sub in _subscribers.values() do
      sub.data_receiver_added(b_id.name, b_id.step_id, dr)
    end

  be request_data_receiver(sender_name: String, sender_boundary_id: U128,
    conn: DataChannel)
  =>
    """
    Called when a DataChannel is first created and needs to know the
    DataReceiver corresponding to the relevant OutgoingBoundary. If this
    is the first time that OutgoingBoundary has connected to this worker,
    then we create a new DataReceiver here.
    """
    let boundary_id = BoundaryId(sender_name, sender_boundary_id)
    let dr =
      try
        _data_receivers(boundary_id)
      else
        let new_dr = DataReceiver(_auth, _worker_name, sender_name,
          _initialized)
        new_dr.update_router(_data_router)
        _data_receivers(boundary_id) = new_dr
        new_dr
      end
    conn.identify_data_receiver(dr, sender_boundary_id)
    _inform_subscribers(boundary_id, dr)

  be start_replay_processing() =>
    for dr in _data_receivers.values() do
      dr.start_replay_processing()
    end

  be start_normal_message_processing() =>
    _initialized = true
    for dr in _data_receivers.values() do
      dr.start_normal_message_processing()
    end

  be update_data_router(dr: DataRouter) =>
    _data_router = dr
    for data_receiver in _data_receivers.values() do
      data_receiver.update_router(_data_router)
    end