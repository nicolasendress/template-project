// app/page.tsx
export default function Home() {
  return (
    <div className="container mt-5">
      <div className="row justify-content-center">
        <div className="col-12 text-center">
          <h1 className="display-4">¡Inicia tu proyecto!</h1>
          <p className="lead">Tecnologías utilizadas:</p>
          <ul className="list-group list-group-flush">
            <li className="list-group-item">Next.js</li>
            <li className="list-group-item">React</li>
            <li className="list-group-item">Bootstrap</li>
            <li className="list-group-item">Turbopack</li>
            <li className="list-group-item">TypeScript</li>
            <li className="list-group-item">MYSQL</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
