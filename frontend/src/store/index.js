import 'regenerator-runtime/runtime'
import { createStore, applyMiddleware, compose  } from 'redux'
import createSagaMiddleware from 'redux-saga'
import sagas from '../sagas'
import rootReducer from '../reducers/index'


const initialiseSagaMiddleware = createSagaMiddleware()
const storeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
const store = createStore(
  rootReducer,
  storeEnhancers(
    applyMiddleware(initialiseSagaMiddleware)
  )
)
initialiseSagaMiddleware.run(sagas)

export default store
