import React from "react"

const NumberListFormatter = ({numbers}) => (
  <div className='number-list'>
    {
      numbers.map(
        (num, index) => (<div key={index}>{num}</div>)
      )
    }
  </div>
)

export default NumberListFormatter
