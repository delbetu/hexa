import { ADD_NUMBER, SET_NEXT_NUMBER, ADD_REMOTE_USER_IDS  } from '../constants/action-types';
import { FETCH_PING, UPDATE_PING_RESULT } from '../constants/action-types'

export const addNumberAction = (number) => ({
  type: ADD_NUMBER,
  payload: number
})

export const setNextNumberAction = (number) => ({
  type: SET_NEXT_NUMBER,
  payload: number
})

export const addRemoteUserIds = () => ({type: ADD_REMOTE_USER_IDS})

export const fetchPing = () => ({ type: FETCH_PING })

export const updatePingResult = (pingResult) => ({
  type: UPDATE_PING_RESULT,
  payload: pingResult
})
