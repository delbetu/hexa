/**
* @jest-environment jsdom
*/
import 'babel-polyfill' // Solve: regeneratorRuntime is not defined
import { act } from 'react-dom/test-utils'
import React from 'react'
import { render, unmountComponentAtNode } from 'react-dom'
import { Provider } from 'react-redux'
import store from '../../store'
import Numbers from './index'

let container = null;
beforeEach(() =>{
  container = document.createElement('div')
  document.body.appendChild(container)
})

afterEach(() => {
  unmountComponentAtNode(container)
  container.remove()
  container = null
})

it('renders fetched numbers', async () => {
  const fakeUsers = [
    { id: 1, name: "First User" },
    { id: 2, name: "Second User" }
  ]

  global.fetch = jest.fn().mockImplementation(() => Promise.resolve({
    json: () => Promise.resolve(fakeUsers),
  }))

  await act(async () => {
    render(
      <Provider store={store}>
        <Numbers />
      </Provider>
      ,container
    )
  })

  expect(container.textContent).toContain('Numbers!')
  expect(container.textContent).toContain('1')
  expect(container.textContent).toContain('2')

  global.fetch.mockClear()
  delete global.fetch
})
