import React, { useState, useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { AppDispatch } from '../store';
import { 
  fetchEmployees, 
  openEmployeeModal, 
  selectEmployees,
  deleteEmployee
} from '../store/employeesSlice';
import { Employee } from '../store/shiftsSlice';
import EmployeeModal from '../components/EmployeeModal';
import CreateEmployeeModal from '../components/CreateEmployeeModal';
import DeleteEmployeeModal from '../components/DeleteEmployeeModal';
import { RootState } from '../types';

const EmployeesPage: React.FC = () => {
  const { t } = useTranslation();
  const dispatch = useDispatch<AppDispatch>();
  const employees = useSelector(selectEmployees);
  const { 
    isModalOpen, 
    selectedEmployee,
    status, 
    error 
  } = useSelector((state: RootState) => state.employees);

  // State for delete confirmation modal
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [employeeToDelete, setEmployeeToDelete] = useState<string | null>(null);

  useEffect(() => {
    if (status === 'idle') {
      dispatch(fetchEmployees());
    }
  }, [status, dispatch]);

  const handleAddEmployee = () => {
    dispatch(openEmployeeModal(null));
  };

  const handleEditEmployee = (employee: Employee) => {
    dispatch(openEmployeeModal(employee));
  };

  const handleDeleteEmployee = (employeeId: string) => {
    setEmployeeToDelete(employeeId);
    setIsDeleteModalOpen(true);
  };

  const handleCloseDeleteModal = () => {
    setIsDeleteModalOpen(false);
    setEmployeeToDelete(null);
  };

  // Loading and error states
  if (status === 'loading') {
    return <div className="text-center py-10">{t('common.loading')}</div>;
  }

  if (status === 'failed') {
    return (
      <div className="text-center py-10 text-red-600">
        {t('common.error')}: {error}
      </div>
    );
  }

  return (
    <div className="container mx-auto p-4">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-800">{t('employees.title')}</h1>
        <div className="flex space-x-4">
          <button
            onClick={handleAddEmployee}
            className="bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 transition-colors"
          >
            {t('employees.addEmployee')}
          </button>
        </div>
      </div>

      {/* Employee Modals */}
      {isModalOpen && !selectedEmployee && <CreateEmployeeModal isOpen={true} />}
      {isModalOpen && selectedEmployee && <EmployeeModal />}

      <DeleteEmployeeModal 
        isOpen={isDeleteModalOpen}
        onClose={handleCloseDeleteModal}
        employeeId={employeeToDelete}
      />

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.name')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.role')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.type')}
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.skills')}
              </th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                {t('employees.actions')}
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {employees.map((employee: Employee) => (
              <tr key={employee.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {employee.name}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {employee.role}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {employee.employmentType}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {employee.skills.join(', ')}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div className="flex justify-end space-x-2">
                    <button
                      onClick={() => handleEditEmployee(employee)}
                      className="text-primary-600 hover:text-primary-900 transition-colors"
                    >
                      {t('common.edit')}
                    </button>
                    <button
                      onClick={() => handleDeleteEmployee(employee.id)}
                      className="text-red-600 hover:text-red-900 transition-colors"
                    >
                      {t('common.delete')}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default EmployeesPage;
