import { combineReducers  } from 'redux'
import { ADD_NUMBER, UPDATE_PING_RESULT, SET_NEXT_NUMBER } from "../constants/action-types";

const initialState = {
  nextNumber: 0,
  numbers: []
}

const rootReducer = (state = initialState, action) => {
  switch (action.type) {
    case ADD_NUMBER:
      return Object.assign({}, state, { nextNumber: state.nextNumber + 1, numbers: state.numbers.concat(action.payload) });
    case SET_NEXT_NUMBER:
      return Object.assign({}, state, { nextNumber: parseInt(action.payload) });
    case UPDATE_PING_RESULT:
      return Object.assign({}, state, { pingResult: action.payload });
    default:
      return state
  }
}

export default rootReducer
