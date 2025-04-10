import { Router, Request, Response } from 'express';
import { pool } from '../config/db';
import { authenticateToken } from '../middleware/auth';

export const userRouter = Router();

// Get user details (protected route)
userRouter.get('/', authenticateToken, async (req: Request, res: Response) => {
  try {
    const result = await pool.query(
      'SELECT id, email, name, created_at FROM users WHERE id = $1',
      [req.userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Server error' });
  }
});
