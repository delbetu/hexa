import 'babel-polyfill' // Solve: regeneratorRuntime is not defined
import React from 'react'
import ReactDOM from 'react-dom'
import { create } from 'react-test-renderer'
import NumberListFormatter from './number-list-formatter'

it('renders passed numbers', () => {
  const component = create(<NumberListFormatter numbers={[1, 2, 3]} />)
  const instance = component.root
  const nums = instance.findByType("div")

  console.log(nums)
  // expect(button.props.children).toBe("PROCEED TO CHECKOUT")
})
