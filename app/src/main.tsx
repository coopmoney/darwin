import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'

function Overlay() {
  return (
    <div
      className="w-[120px] h-[120px] flex items-center justify-center bg-transparent"
      onClick={() => (window as any).darwinAPI?.openMain?.()}
    >
      <img src={('/activation.png')} alt="Darwin" className="w-full h-full object-contain select-none" draggable={false} />
    </div>
  )
}

const isOverlay = window.location.hash === '#overlay'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    {isOverlay ? <Overlay /> : <App />}
  </React.StrictMode>,
)
