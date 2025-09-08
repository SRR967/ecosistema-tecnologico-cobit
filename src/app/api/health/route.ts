import { NextResponse } from "next/server";
import pool from "../../../lib/database";

export async function GET() {
  try {
    // Verificar conexión a la base de datos
    const result = await pool.query('SELECT 1 as health_check');
    
    if (result.rows.length > 0) {
      return NextResponse.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        database: 'connected',
        version: process.env.npm_package_version || '1.0.0'
      });
    } else {
      throw new Error('No response from database');
    }
  } catch (error) {
    console.error('Health check failed:', error);
    return NextResponse.json(
      {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        database: 'disconnected',
        error: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 503 }
    );
  }
}
