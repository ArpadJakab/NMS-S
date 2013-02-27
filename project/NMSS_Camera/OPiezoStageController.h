
#ifndef OPIEZOSTAGECONTROLLER_H
#define OPIEZOSTAGECONTROLLER_H

#include <string>


class OPiezoStageController {

private:
	int m_nHController;

public:
	OPiezoStageController();
	OPiezoStageController(bool bGUI) throw(std::string);
	~OPiezoStageController();

	void Connect(bool bGUI) throw(std::string);
	std::string GetIDString() throw(std::string);

private:
	int GetErrorID();
	std::string GetErrorString();
	std::string GetErrorString(int iErrorID);


};

#endif //OPIEZOSTAGECONTROLLER_H