// app/api/time/route.ts
import db from '@/lib/db';
import { NextResponse } from 'next/server';
import { RowDataPacket } from 'mysql2';

export async function GET() {
  try {
    // Ejecuta la consulta para obtener la hora actual desde la base de datos
    const [rows] = await db.query<RowDataPacket[]>('SELECT NOW() as now');

    if (!rows || rows.length === 0) {
      return NextResponse.json({ error: 'No se encontraron datos' }, { status: 404 });
    }

    return NextResponse.json({ time: rows[0].now }, { status: 200 });
  } catch (error) {
    console.error('Error en la conexión a MySQL:', error);
    return NextResponse.json({ error: 'Error en la conexión a MySQL' }, { status: 500 });
  }
}
