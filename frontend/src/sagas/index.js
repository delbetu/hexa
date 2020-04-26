import { takeEvery, call, put, fork, all } from "redux-saga/effects";
import { addNumberAction, updatePingResult } from "../actions";
import { ADD_REMOTE_USER_IDS, FETCH_PING } from "../constants/action-types";

function* watcherSaga() {
  yield takeEvery(ADD_REMOTE_USER_IDS, workerAddRemoteUserIds);
}

function* workerAddRemoteUserIds() {
  try {
    const ids = yield call(fetchUserIds);

    for (let i = 0; i < ids.length; i++) {
      let id = ids[i];
      yield put(addNumberAction(id));
    }
  } catch (e) {
    yield put({ type: "API_ERRORED", payload: e });
  }
}

function fetchUserIds() {
  return fetch("https://jsonplaceholder.typicode.com/users")
    .then(response => response.json())
    .then(users => users.map(u => u.id));
}

function fetchPing() {
  return fetch("http://localhost:3000/ping") // Expected { value: 'some value' }
    .then(response => response.json())
    .then(response => response.value);
}

function* workerShowPingResult() {
  // PENDING: Manage errors
  const pingResult = yield call(fetchPing);

  yield put(updatePingResult(pingResult));
}

function* watchShowPingResult() {
  yield takeEvery(FETCH_PING, workerShowPingResult);
}

export default function* root() {
  yield all([fork(watchShowPingResult), fork(watcherSaga)]);
}
