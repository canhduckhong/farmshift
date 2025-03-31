import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { RootState } from '../store';
import { assignShift, closeModal, availableSkills as defaultSkills } from '../store/shiftsSlice';
import Modal from './Modal';

const AssignShiftModal: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useDispatch();
  const selectedShift = useSelector((state: RootState) => state.shifts.selectedShift);
  const employees = useSelector((state: RootState) => state.shifts.employees);
  
  const [employeeId, setEmployeeId] = useState<string>('');
  const [role, setRole] = useState<string | null>(null);
  
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (employeeId) {
      dispatch(assignShift({ employeeId, role }));
    }
  };
  
  const handleCancel = () => {
    dispatch(closeModal());
  };
  
  const handleRoleChange = (taskRole: string) => {
    setRole(taskRole);
  };
  
  if (!selectedShift) return null;
  
  return (
    <Modal 
      isOpen={!!selectedShift} 
      onClose={handleCancel}
      title={`${t('shiftAssignment.assignTo')} ${t(`days.${selectedShift.day.toLowerCase()}`)}, ${t(`timeSlots.${selectedShift.timeSlot.toLowerCase()}`)}`}
    >
      <form onSubmit={handleSubmit}>
        <div className="mb-4">
          <label htmlFor="employee" className="block text-sm font-medium text-gray-700 mb-1">
            {t('shiftAssignment.assignEmployee')}
          </label>
          <select
            id="employee"
            className="w-full border border-gray-300 rounded-md py-2 px-3 focus:outline-none focus:ring-2 focus:ring-primary-500"
            value={employeeId}
            onChange={(e) => setEmployeeId(e.target.value)}
            required
          >
            <option value="">{t('shiftAssignment.selectEmployee')}</option>
            {employees.map((employee) => (
              <option key={employee.id} value={employee.id}>
                {employee.name} ({employee.role})
              </option>
            ))}
          </select>
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {t('shiftAssignment.selectRole')}
          </label>
          <div className="flex flex-wrap gap-2">
            {defaultSkills.map((taskRole) => (
              <button
                key={taskRole}
                type="button"
                onClick={() => handleRoleChange(taskRole)}
                className={`px-3 py-1 rounded-full text-sm ${
                  role === taskRole 
                    ? 'bg-primary-600 text-white' 
                    : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
                }`}
              >
                {taskRole}
              </button>
            ))}
          </div>
        </div>

        <div className="flex justify-end space-x-2">
          <button
            type="button"
            onClick={handleCancel}
            className="px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300"
          >
            {t('common.cancel')}
          </button>
          <button
            type="submit"
            disabled={!employeeId || !role}
            className="px-4 py-2 bg-primary-600 text-white rounded-md hover:bg-primary-700 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {t('shiftAssignment.assign')}
          </button>
        </div>
      </form>
    </Modal>
  );
};

export default AssignShiftModal;
