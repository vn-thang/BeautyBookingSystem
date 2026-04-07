import React, { useState, useEffect } from 'react';
import { Form, InputNumber, Button, message, Space, Tooltip } from 'antd';
import { InfoCircleOutlined, SaveOutlined } from '@ant-design/icons';
import { storeApi } from '../../api/storeApi';

const StoreFeeConfig = ({ store, onConfigUpdated }) => {
  const [form] = Form.useForm();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (store) {
      form.setFieldsValue({
        commissionRate: store.commissionRate, 
        monthlyAppFee: store.monthlyAppFee || 0 
      });
    }
  }, [store, form]);

  const handleSaveConfig = async (values) => {
    setLoading(true);
    try {
      await storeApi.updateStoreFeeConfig(store.id, values);
      message.success('Cập nhật cấu hình phí thành công!');
      if (onConfigUpdated) onConfigUpdated();
    } catch (error) {
      message.error(error.response?.data?.message || 'Cập nhật cấu hình phí thất bại!');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Form form={form} layout="vertical" onFinish={handleSaveConfig}>
      <div style={{ display: 'flex', gap: '24px', flexWrap: 'wrap' }}>
        <Form.Item 
          name="commissionRate" 
          label={
            <Space>
              <span style={{ fontWeight: 500, color: '#475569' }}>Hoa hồng mỗi đơn (Commission Rate)</span>
              <Tooltip title="Nếu để trống, hệ thống sẽ áp dụng mức hoa hồng mặc định chung.">
                <InfoCircleOutlined style={{ color: '#94a3b8' }} />
              </Tooltip>
            </Space>
          }
          style={{ flex: 1, minWidth: '250px' }}
        >
          <InputNumber addonAfter="%" min={0} max={100} style={{ width: '100%' }} size="large" placeholder="Để trống để dùng mặc định" />
        </Form.Item>

        <Form.Item 
          name="monthlyAppFee" 
          label={<span style={{ fontWeight: 500, color: '#475569' }}>Phí duy trì ứng dụng (VNĐ/Tháng)</span>}
          rules={[{ required: true, message: 'Vui lòng nhập phí duy trì!' }]}
          style={{ flex: 1, minWidth: '250px' }}
        >
          <InputNumber 
            addonAfter="VNĐ" 
            min={0} 
            formatter={(value) => `${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ',')}
            parser={(value) => value?.replace(/\$\s?|(,*)/g, '')}
            style={{ width: '100%' }} 
            size="large"
          />
        </Form.Item>
      </div>

      <div style={{ textAlign: 'right' }}>
        <Button type="primary" htmlType="submit" icon={<SaveOutlined />} loading={loading} style={{ backgroundColor: '#6366F1', borderColor: '#6366F1', padding: '0 24px' }} size="large">
          Lưu cấu hình phí
        </Button>
      </div>
    </Form>
  );
};

export default StoreFeeConfig;