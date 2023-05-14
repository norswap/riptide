import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Cards } from "./pages/cards";
import { Home } from "./pages/home";
import Unpack from "./pages/unpack";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/cards" element={<Cards />} />
        <Route path="/unpack" element={<Unpack />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
